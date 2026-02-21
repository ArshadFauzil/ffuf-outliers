import java.util.*;
import java.util.regex.*;
import java.io.*;

/**
 * Identifies outliers from ffuf output based on response size z-scores.
 * Lines with |z-score| > 3 are considered outliers (hits).
 */
public class FfufOutlierDetector {

    private static final String RED = "\033[0;31m";
    private static final String RESET = "\033[0m";

    // Matches ffuf output: TOKEN [Status: 200, Size: 1814, ...]
    private static final Pattern LINE_PATTERN = Pattern.compile(
        "^(.+?)\\s+\\[Status:\\s*\\d+,\\s*Size:\\s*(\\d+)"
    );

    public static void main(String[] args) {
        if (args.length < 1) {
            System.err.println("Usage: java FfufOutlierDetector <input_file>");
            System.exit(1);
        }

        String fileName = args[0];
        Map<String, Integer> tokenToSize = new LinkedHashMap<>();

        try (BufferedReader br = new BufferedReader(new FileReader(fileName))) {
            String line;
            while ((line = br.readLine()) != null) {
                Matcher m = LINE_PATTERN.matcher(line.trim());
                if (m.find()) {
                    String token = m.group(1).trim();
                    int size = Integer.parseInt(m.group(2));
                    tokenToSize.put(token, size);
                }
            }
        } catch (IOException e) {
            System.err.println("Error reading file: " + e.getMessage());
            System.exit(1);
        }

        if (tokenToSize.isEmpty()) {
            System.err.println("No valid ffuf lines found.");
            System.exit(1);
        }

        // Calculate mean
        double sum = 0;
        for (int size : tokenToSize.values()) {
            sum += size;
        }
        double mean = sum / tokenToSize.size();

        // Calculate population standard deviation
        double varianceSum = 0;
        for (int size : tokenToSize.values()) {
            varianceSum += Math.pow(size - mean, 2);
        }
        double stdDev = Math.sqrt(varianceSum / tokenToSize.size());
        if (stdDev == 0) {
            stdDev = 1; // Avoid division by zero when all sizes are identical
        }

        // Print header
        System.out.println("Outliers (|z-score| > 3):");
        System.out.printf("Mean: %.2f | Std Dev: %.2f%n", mean, stdDev);
        System.out.println();

        // Identify and print outliers in red
        for (Map.Entry<String, Integer> entry : tokenToSize.entrySet()) {
            String token = entry.getKey();
            int size = entry.getValue();
            double zScore = (size - mean) / stdDev;
            if (Math.abs(zScore) > 3) {
                System.out.println(RED + "Token: " + token + " | Size: " + size + RESET);
            }
        }
    }
}

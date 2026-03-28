# FFUF outlier detector

Reads saved [ffuf](https://github.com/ffuf/ffuf) output, extracts each line’s response **Size**, and flags **outliers** where the absolute z-score is greater than **3** (compared to the mean of all sizes). Outlier rows are printed in **red** in the terminal.

## Requirements

- **Java** (`java` and `javac` on your `PATH`)

## Usage

From this directory:

```bash
chmod +x ffuf_outlier_detector.sh   # once, if needed
./ffuf_outlier_detector.sh -f <path_to_ffuf_output>
```

You can also pass the file as the first argument:

```bash
./ffuf_outlier_detector.sh <path_to_ffuf_output>
```

The script compiles `FfufOutlierDetector.java` when needed, then runs it.

### Run Java directly (optional)

```bash
javac FfufOutlierDetector.java
java FfufOutlierDetector <path_to_ffuf_output>
```

## Example

1. Capture ffuf output to a file (or use the included sample):

   ```bash
   ./ffuf_outlier_detector.sh -f sample_ffuf_output.txt
   ```

2. Typical output shape:

   - A short summary line with **mean** and **standard deviation** of sizes.
   - Any outlier printed in red as: `Token: … | Size: …`

Each input line should look like ffuf’s result format, for example:

```text
/admin                [Status: 200, Size: 1820, Words: 498, Lines: 48, Duration: 21ms]
```

Lines that do not match this pattern are skipped.

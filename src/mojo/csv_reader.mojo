# ============================================================================
# CSV Reader — OHLCV Market Data Parser
# ============================================================================
# Reads OHLCV CSV files (EODHD format) into Mojo structs.
#
# Supports both daily and intraday formats:
#   Daily:    Date,Open,High,Low,Close,Adjusted_close,Volume
#             2015-01-02,206.38,206.88,204.18,205.43,177.91,55791000
#
#   Intraday: Date,Open,High,Low,Close,Adjusted_close,Volume
#             2024-01-02 09:30:00,472.65,473.92,468.50,472.65,472.65,55000000
#
# Design:
#   - Uses String.split(",") for CSV parsing
#   - All numeric fields as Float64 (volume included)
#   - Dates as String (YYYY-MM-DD or YYYY-MM-DD HH:MM:SS)
#   - Flat List storage per column for efficient iteration
# ============================================================================


# ============================================================================
# Parse Helpers
# ============================================================================

fn _parse_float(s: String) -> Float64:
    """Parse a string to Float64. Returns 0.0 on failure."""
    var stripped = s.strip()
    if len(stripped) == 0:
        return 0.0
    try:
        return atof(stripped)
    except:
        return 0.0


# ============================================================================
# OHLCVData Struct
# ============================================================================

struct OHLCVData(Copyable, Movable):
    """OHLCV time series for a single asset.

    All arrays have the same length (n_rows).
    dates[i] corresponds to open[i], high[i], etc.
    """
    var dates: List[String]
    var open: List[Float64]
    var high: List[Float64]
    var low: List[Float64]
    var close: List[Float64]
    var adj_close: List[Float64]
    var volume: List[Float64]
    var ticker: String

    fn __init__(out self, ticker: String):
        self.ticker = ticker
        self.dates = List[String]()
        self.open = List[Float64]()
        self.high = List[Float64]()
        self.low = List[Float64]()
        self.close = List[Float64]()
        self.adj_close = List[Float64]()
        self.volume = List[Float64]()

    fn __moveinit__(out self, deinit existing: Self):
        self.ticker = existing.ticker^
        self.dates = existing.dates^
        self.open = existing.open^
        self.high = existing.high^
        self.low = existing.low^
        self.close = existing.close^
        self.adj_close = existing.adj_close^
        self.volume = existing.volume^

    fn __copyinit__(out self, existing: Self):
        self.ticker = existing.ticker
        self.dates = List[String]()
        for i in range(len(existing.dates)):
            self.dates.append(existing.dates[i])
        self.open = List[Float64]()
        for i in range(len(existing.open)):
            self.open.append(existing.open[i])
        self.high = List[Float64]()
        for i in range(len(existing.high)):
            self.high.append(existing.high[i])
        self.low = List[Float64]()
        for i in range(len(existing.low)):
            self.low.append(existing.low[i])
        self.close = List[Float64]()
        for i in range(len(existing.close)):
            self.close.append(existing.close[i])
        self.adj_close = List[Float64]()
        for i in range(len(existing.adj_close)):
            self.adj_close.append(existing.adj_close[i])
        self.volume = List[Float64]()
        for i in range(len(existing.volume)):
            self.volume.append(existing.volume[i])

    fn n_rows(self) -> Int:
        return len(self.close)


# ============================================================================
# CSV Reader
# ============================================================================

fn read_csv_ohlcv(path: String, ticker: String) -> OHLCVData:
    """Read an EODHD-format CSV file into OHLCVData.

    Expected header: Date,Open,High,Low,Close,Adjusted_close,Volume
    Skips the header line. Parses all subsequent lines.
    Supports both daily (YYYY-MM-DD) and intraday (YYYY-MM-DD HH:MM:SS) dates.

    Args:
        path: Filesystem path to CSV file.
        ticker: Ticker symbol (stored in result).

    Returns:
        OHLCVData with parsed columns.
    """
    var data = OHLCVData(ticker)

    try:
        with open(path, "r") as f:
            var content = f.read()

            # Split content into lines
            var lines = content.split("\n")

            # Skip header (line 0), parse data lines
            for row_idx in range(1, len(lines)):
                var line = lines[row_idx].strip()
                if len(line) == 0:
                    continue

                var fields = line.split(",")
                if len(fields) < 7:
                    continue

                data.dates.append(String(String(fields[0]).strip()))
                data.open.append(_parse_float(String(fields[1])))
                data.high.append(_parse_float(String(fields[2])))
                data.low.append(_parse_float(String(fields[3])))
                data.close.append(_parse_float(String(fields[4])))
                data.adj_close.append(_parse_float(String(fields[5])))
                data.volume.append(_parse_float(String(fields[6])))

    except e:
        print("ERROR reading CSV", path, ":", e)

    return data^


fn read_csv_ohlcv_intraday(path: String, ticker: String) -> OHLCVData:
    """Read intraday CSV into OHLCVData. Alias for read_csv_ohlcv.

    Same format but dates contain time component (YYYY-MM-DD HH:MM:SS).
    The parser is identical — this alias exists for clarity and documentation.

    Args:
        path: Filesystem path to CSV file.
        ticker: Ticker symbol.

    Returns:
        OHLCVData with datetime strings in the dates field.
    """
    return read_csv_ohlcv(path, ticker)


# ============================================================================
# Inline Validation
# ============================================================================

fn main() raises:
    print("=" * 60)
    print("csv_reader — Inline Validation")
    print("=" * 60)

    # Write a small test CSV
    var test_path = "/tmp/test_ohlcv.csv"
    try:
        with open(test_path, "w") as f:
            f.write("Date,Open,High,Low,Close,Adjusted_close,Volume\n")
            f.write("2024-01-02,472.65,473.92,468.50,472.65,472.65,55000000\n")
            f.write("2024-01-03,471.50,473.12,469.80,470.92,470.92,48000000\n")
            f.write("2024-01-04,469.30,470.80,466.20,467.33,467.33,52000000\n")
    except:
        print("Could not write test CSV")
        return

    var data = read_csv_ohlcv(test_path, "TEST")
    print("  ticker:", data.ticker)
    print("  n_rows:", data.n_rows())

    var passed = 0
    var failed = 0

    # Check row count
    if data.n_rows() == 3:
        print("  PASS: 3 rows parsed")
        passed += 1
    else:
        print("  FAIL: expected 3 rows, got", data.n_rows())
        failed += 1

    # Check date
    if data.dates[0] == "2024-01-02":
        print("  PASS: date[0] =", data.dates[0])
        passed += 1
    else:
        print("  FAIL: date[0] =", data.dates[0])
        failed += 1

    # Check close price
    var abs_diff = data.close[0] - 472.65
    if abs_diff < 0.0:
        abs_diff = -abs_diff
    if abs_diff < 0.01:
        print("  PASS: close[0] =", data.close[0])
        passed += 1
    else:
        print("  FAIL: close[0] =", data.close[0], "expected 472.65")
        failed += 1

    # Check volume
    if data.volume[2] == 52000000.0:
        print("  PASS: volume[2] =", data.volume[2])
        passed += 1
    else:
        print("  FAIL: volume[2] =", data.volume[2])
        failed += 1

    print()
    if failed == 0:
        print("csv_reader: ALL", passed, "PASS")
    else:
        print("csv_reader:", passed, "PASS,", failed, "FAIL")
    print("=" * 60)

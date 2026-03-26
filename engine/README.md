# Signal Engine (Proprietary)

This directory contains the live TDA signal engine written in Mojo.

**Not included in the public repository.**

The engine computes a directional signal (LONG / SHORT / FLAT) from the
cross-sectional topology of ~250 cryptocurrency futures returns using:

- Johnson-Lindenstrauss random projection
- Vietoris-Rips filtration
- Persistent homology (boundary matrix reduction)
- Cocycle extraction & Hodge decomposition
- Path signature scoring for asset selection

The full pipeline runs in <30ms per bar (100x faster than Python equivalents).

Output: `data/{exchange}/signal.txt` — consumed by the Python execution layer.

For the technical overview, see [CryptoVortex Overview (PDF)](../docs/CryptoVortex_Overview.pdf).

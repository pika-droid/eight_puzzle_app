import 'dart:ui' as ui;

/// Utility class to slice an image into 9 equal segments for the 8-puzzle.
class ImageSlicer {
  /// Cache to store sliced images by source image hashCode.
  static final Map<int, List<ui.Image>> _cache = {};

  /// Slices the [source] image into 9 equal segments (3x3 grid).
  ///
  /// Returns a list of 9 [ui.Image] objects, indexed 0-8 corresponding to
  /// positions in the puzzle grid (row-major order).
  ///
  /// Results are cached based on the source image hashCode.
  static Future<List<ui.Image>> sliceImage(ui.Image source) async {
    final int cacheKey = source.hashCode;

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final int tileWidth = source.width ~/ 3;
    final int tileHeight = source.height ~/ 3;

    final List<ui.Image> tiles = [];

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final ui.Image tile = await _extractTile(
          source,
          col * tileWidth,
          row * tileHeight,
          tileWidth,
          tileHeight,
        );
        tiles.add(tile);
      }
    }

    _cache[cacheKey] = tiles;
    return tiles;
  }

  /// Extracts a single tile from the source image.
  static Future<ui.Image> _extractTile(
    ui.Image source,
    int x,
    int y,
    int width,
    int height,
  ) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    // Draw the cropped portion of the source image
    canvas.drawImageRect(
      source,
      ui.Rect.fromLTWH(
        x.toDouble(),
        y.toDouble(),
        width.toDouble(),
        height.toDouble(),
      ),
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint(),
    );

    final ui.Picture picture = recorder.endRecording();
    return picture.toImage(width, height);
  }

  /// Clears the cache. Call this when the source image changes.
  static void clearCache() {
    _cache.clear();
  }
}


from PIL import Image
import sys

def detect_grid():
    try:
        img = Image.open('data/Baraja_española_completa.png')
    except Exception as e:
        print(f"Error opening image: {e}")
        return

    gray = img.convert('L')
    width, height = gray.size
    print(f"Image WxH: {width}x{height}")
    
    pixels = gray.load()

    # Analyze Columns
    # We define "activity" as the difference between max and min pixel in a sample of the column
    col_activity = []
    step = 5
    for x in range(0, width):
        # Sample vertically
        vals = []
        for y in range(0, height, 10):
            vals.append(pixels[x,y])
        
        if vals:
            activity = max(vals) - min(vals)
            col_activity.append(activity)
        else:
            col_activity.append(0)

    # Analyze Rows
    row_activity = []
    for y in range(0, height):
        vals = []
        for x in range(0, width, 10):
            vals.append(pixels[x,y])
        
        if vals:
            activity = max(vals) - min(vals)
            row_activity.append(activity)
        else:
            row_activity.append(0)

    # Visualizing the profile
    # "0" means low activity (gap), "1-9" means high activity (card content)
    
    def print_profile(activity_list, label):
        print(f"\n{label} Profile:")
        out = ""
        # Downsample for printing - fit in ~80 chars
        # Total list len is width or height (2496 or 1595)
        # 2496 / 80 approx 30 pixels per char
        
        chunk_size = len(activity_list) // 80 if len(activity_list) > 80 else 1
        
        for i in range(0, len(activity_list), chunk_size):
            chunk = activity_list[i:i+chunk_size]
            avg_act = sum(chunk) / len(chunk)
            
            # Threshold: < 20 is probably white/gray gap. > 50 is content.
            # Map 0-255 to 0-9 roughly
            digit = int((avg_act / 255.0) * 9)
            if avg_act < 20:
                out += "."
            else:
                out += "#"
        print(out)
        
    print_profile(col_activity, "Column")
    print_profile(row_activity, "Row")
    
    # Try to find start/end of cards based on transitions
    # Simple state machine: Gap -> Card -> Gap
    
    def find_segments(activity_list, threshold=20):
        segments = []
        in_segment = False
        start = 0
        
        # Smoothen?
        # Just iterate
        for i, act in enumerate(activity_list):
            is_active = act > threshold
            
            if is_active and not in_segment:
                in_segment = True
                start = i
            elif not is_active and in_segment:
                in_segment = False
                end = i
                # Filter noise
                if (end - start) > 10:
                    segments.append((start, end))
                    
        if in_segment:
            segments.append((start, len(activity_list)))
            
        return segments

    col_segs = find_segments(col_activity)
    row_segs = find_segments(row_activity)
    
    print(f"\nFound {len(col_segs)} column segments (potential cards)")
    print(f"First 5 cols: {col_segs[:5]}")
    
    print(f"Found {len(row_segs)} row segments (potential cards)")
    print(f"First 5 rows: {row_segs[:5]}")
    
    # Output average width/height
    if col_segs:
        avg_w = sum(e-s for s,e in col_segs) / len(col_segs)
        print(f"Average Card Width: {avg_w:.1f}")
        
    if row_segs:
        avg_h = sum(e-s for s,e in row_segs) / len(row_segs)
        print(f"Average Card Height: {avg_h:.1f}")

if __name__ == "__main__":
    detect_grid()

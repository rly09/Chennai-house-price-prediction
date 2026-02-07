from PIL import Image, ImageDraw
import os

# Ensure directory exists
os.makedirs('c:/Users/yogir/Chennai house price prediction/frontend/assets/icon', exist_ok=True)

img = Image.new('RGB', (1024, 1024), color='#1e5631') # Deep Green
d = ImageDraw.Draw(img)

# Draw House Body (White)
d.rectangle([256, 450, 768, 850], fill='white')

# Draw Roof (White Triangle)
d.polygon([(150, 450), (512, 100), (874, 450)], fill='white')

# Draw Door (Green)
d.rectangle([462, 600, 562, 850], fill='#1e5631')

# Draw Window (Green)
d.rectangle([300, 550, 400, 650], fill='#1e5631')
d.rectangle([624, 550, 724, 650], fill='#1e5631')

img.save('c:/Users/yogir/Chennai house price prediction/frontend/assets/icon/urbannest_app_icon.png')
print("Icon created successfully")

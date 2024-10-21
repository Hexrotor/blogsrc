import os
from concurrent.futures import ThreadPoolExecutor

PATH = "./public/images/post_imgs/"

def convert_image(filename):
    newfilename = filename.rsplit(".", 1)[0] + ".avif"
    try:
        os.system(f"ffmpeg -i {filename} -threads 16 {newfilename} -y")
        # os.remove(filename)
    except Exception as e:
        print(f"Error: {filename} {e}")
        exit(1)


def traverse_and_convert(path):
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = []
        for root, _, files in os.walk(path):
            for filename in files:
                if filename.lower().endswith((".jpg", ".png", ".jpeg", ".gif", ".bmp")) and not filename.lower().rsplit(".", 1)[0].endswith("_raw"):
                    full_path = os.path.join(root, filename)
                    futures.append(executor.submit(convert_image, full_path))
        for future in futures:
            future.result()

traverse_and_convert(PATH)
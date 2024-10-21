import os
import re
def replace_jsdelivr_links(file_path):
    new_base_url = "https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/"
    old_base_url = "imgs/"
    
    def replace_image_links(markdown_text):
        def replace_link(match):
            url = match.group(2)
            if re.search(r'_raw\.(jpg|png|jpeg|gif|bmp)$', url, re.IGNORECASE) or url.endswith(".avif"):
                return f'![{match.group(1)}]({url})'
            else:
                return f'![{match.group(1)}]({url+".avif"})'
        
        pattern = re.compile(r'!\[(.*?)\]\((.*?)\)')
        return pattern.sub(replace_link, markdown_text)
    
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    content = re.sub(r'(\!\[.*\]\()' + re.escape(old_base_url), r'\1' + new_base_url, content)
    content = replace_image_links(content)
    # print(content)
    
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(content)


for filename in os.listdir('source/_posts/'):
    file_path = os.path.join('source/_posts/', filename)
    if os.path.isfile(file_path):
        replace_jsdelivr_links(file_path)
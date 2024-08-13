# pip install pyautogui
# f' "截圖儲存路徑"/"截圖檔案名稱"{i}.png '

import pyautogui
from time import sleep

i = 0
while 1:
    i += 1
    myScreenshot = pyautogui.screenshot()
    myScreenshot.save(
        f'D:\Sc/test{i}.png')
    sleep(5)

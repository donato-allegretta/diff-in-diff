import pandas as pd
import os
import glob
import numpy as np
import jellyfish as jf
from fuzzywuzzy import fuzz

path = r'C:\Users\donat\OneDrive\Desktop\Tesi/postcodes'
all_files = glob.glob(path + "/*.csv")

li = []

for filename in all_files:
    df = pd.read_csv(filename)
    
    li.append(df)

frame = pd.concat(li, axis=0, ignore_index=True)
frame.to_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/append.csv', index=False)
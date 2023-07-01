
import pandas as pd

registry_names = ['id', 'price', 'date', 'postcode', 'property_type', 'old/new', 'duration', 'PAON', 'SAON', 'street', 'locality', 'city', 'district', 'county', 'ppd category', 'record status']
house_registry = pd.read_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/pp-complete.csv', names=registry_names)
postal_codes = pd.read_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/append.csv')

selected = house_registry.loc[house_registry['postcode'].isin(postal_codes['postcode'])]

final = selected.merge(postal_codes, on='postcode')

final.to_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/final_dataset.csv', index=False)



final_dataset = pd.read_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/final_dataset.csv')
solar = final_dataset.loc[final_dataset['Technology'] == 'Solar']
wind = final_dataset.loc[final_dataset['Technology'] == 'Wind (Onshore)']
ccgt = final_dataset.loc[final_dataset['Technology'] == 'CCGT']
bioenergy = final_dataset.loc[final_dataset['Technology'] == 'Bioenergy']
conventional_steam = final_dataset.loc[final_dataset['Technology'] == 'Conventional Steam']
ocgt = final_dataset.loc[final_dataset['Technology'] == 'OCGT']


solar.to_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/solar.csv', index=False)
wind.to_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/wind.csv', index=False)
ccgt.to_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/ccgt.csv', index=False)
bioenergy.to_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/bioenergy.csv', index=False)
conventional_steam.to_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/conventional_steam.csv', index=False)
ocgt.to_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/ocgt.csv', index=False)

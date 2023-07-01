import pandas as pd

postal_names = ['postcode', 'km', 'miles']
postal_codes = pd.read_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/postcodes/Fellside CHP.csv', names=postal_names)
station_data = pd.read_excel(r'C:\Users\donat\OneDrive\Desktop\Tesi/Power plants location.xlsx')

station_data.drop('Fuel', axis=1, inplace=True)
station_data.drop('Address', axis=1, inplace=True)
station_data.drop('Address 2', axis=1, inplace=True)
station_data.drop('Address complete', axis=1, inplace=True)
station_data.drop('Location', axis=1, inplace=True)

postal_codes['Station Name'] = 'Fellside CHP'
postal_codes = postal_codes.merge(station_data, on='Station Name')

postal_codes.to_csv(r'C:\Users\donat\OneDrive\Desktop\Tesi/postcodes/Fellside CHP.csv', index=False)

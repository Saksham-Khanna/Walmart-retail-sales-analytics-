import csv

with open('data/Walmart_Sales.csv', 'r') as f_in, open('sql/insert_staging.sql', 'w') as f_out:
    reader = csv.reader(f_in)
    next(reader) # skip header
    f_out.write('USE walmart_sales;\n')
    f_out.write('INSERT INTO staging_sales (Store, Date, Weekly_Sales, Holiday_Flag, Temperature, Fuel_Price, CPI, Unemployment) VALUES\n')
    
    values = []
    for row in reader:
        # Format the row as SQL values
        val_str = f"({row[0]}, '{row[1]}', {row[2]}, {row[3]}, {row[4]}, {row[5]}, {row[6]}, {row[7]})"
        values.append(val_str)
        
    # Write them comma separated
    f_out.write(',\n'.join(values) + ';\n')
    print("insert_staging.sql has been created successfully!")

import pandas as pd
import json
import sys

file_path = sys.argv[1]

df = pd.read_csv(file_path, nrows=0)


string_val = "STRING"


raw_list = []
for i in df.columns:
   raw_list.append({"name": i, "type": string_val, "mode": "NULLABLE"})

processed_json = json.dumps(raw_list, indent=2)

print(processed_json)

output_path = sys.argv[2]

with open(output_path, "w") as f:
    f.write(processed_json)

print(f"Schema with {len(raw_list)} columns written to {output_path}")
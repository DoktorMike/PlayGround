from io import StringIO
import pandas as pd

csvstring = """name, smiles
Paracetamol, CC(=O)Nc1ccc(O)cc1
Omeprazole, CC1=CN=C(C(=C1OC)C)CS(=O)C2=NC3=C(N2)C=C(C=C3)OC
Telaprevir, CCC[C@@H](C(=O)C(=O)NC1CC1)NC(=O)[C@@H]2[C@H]3CCC[C@H]3CN2C(=O)[C@H](C(C)(C)C)NC(=O)[C@H](C4CCCCC4)NC(=O)c5cnccn5
Eltrombopag, CC1=C(C=C(C=C1)N2C(=O)C(=C(N2)C)N=NC3=CC=CC(=C3O)C4=CC(=CC=C4)C(=O)O)C
"""
csvstringio = StringIO(csvstring)
df1 = pd.read_csv(csvstringio, sep=",", skipinitialspace=True)
csvstringio = StringIO(csvstring)
df2 = pd.read_csv(csvstringio, sep=",")
set(df1.columns) == set(df2.columns) # WTF!

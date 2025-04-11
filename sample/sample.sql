--Encrypt your password for source and target
SELECT encrypt_password('YourPassword')

--Execute the fonction to execute fasttransfer
SELECT call_fasttransfer(
    sourceconnectiontype := 'mssql',
    sourceserver := '10.66.3.121,21433',
    sourceuser := 'FastUser',
    sourcepassword := 'gAAAAABn-Rp9l7qH9q3aDx1_s-KUEgfFt-qBoh9H7OKqcDplxoFaWvoQv-fcFSKKU0Qq5mDyuJ8NkMwZs61GVrwsH6uHgqhJLg==',
    sourcedatabase := 'WIKIPEDIA',
    sourceschema := 'dbo',
    sourcetable := 'dbpedia_14_10K',
    targetconnectiontype := 'pgcopy',
    targetserver := 'localhost',
    targetuser := 'postgres',
    targetpassword := 'gAAAAABn-RoNwes9czqg_h4SU1IWrpkheI3LRml7RFjfcLmDzK25TtRO4ioduL2OALF3LEKc2Ew_yCJeMvn7HYJBhsscaKWiyQ==',
    targetdatabase := 'postgres',
    targetschema := 'public',
    targettable := 'dbpediamini',
    method := 'None',
    loadmode := 'Truncate',
    batchsize := 1048576,
   	useworktables := True
);
CREATE OR REPLACE FUNCTION FastWrappers_PGSQL(
    sourceconnectiontype TEXT DEFAULT NULL,
    sourceconnectstring TEXT DEFAULT NULL,
    sourcedsn TEXT DEFAULT NULL,
    sourceprovider TEXT DEFAULT NULL,
    sourceserver TEXT DEFAULT NULL,
    sourceuser TEXT DEFAULT NULL,
    sourcepassword TEXT DEFAULT NULL,
    sourcetrusted BOOLEAN DEFAULT FALSE,
    sourcedatabase TEXT DEFAULT NULL,
    sourceschema TEXT DEFAULT NULL,
    sourcetable TEXT DEFAULT NULL,
    query TEXT DEFAULT NULL,
    fileinput TEXT DEFAULT NULL,
    targetconnectiontype TEXT DEFAULT NULL,
    targetconnectstring TEXT DEFAULT NULL,
    targetserver TEXT DEFAULT NULL,
    targetuser TEXT DEFAULT NULL,
    targetpassword TEXT DEFAULT NULL,
    targettrusted BOOLEAN DEFAULT FALSE,
    targetdatabase TEXT DEFAULT NULL,
    targetschema TEXT DEFAULT NULL,
    targettable TEXT DEFAULT NULL,
    degree INTEGER DEFAULT 1,
    method TEXT DEFAULT 'None',
    distributekeycolumn TEXT DEFAULT NULL,
    datadrivenquery TEXT DEFAULT NULL,
    loadmode TEXT DEFAULT 'Append',
    batchsize INTEGER DEFAULT 1048576,
    useworktables BOOLEAN DEFAULT FALSE,
    runid TEXT DEFAULT NULL,
    settingsfile TEXT DEFAULT NULL,
    mapmethod TEXT DEFAULT 'Position'
)
RETURNS int AS $$

######################################################################
### Import subprocess and cryptography
#######################################################################
import subprocess
from cryptography.fernet import Fernet

######################################################################
### Decrypt password
#######################################################################
key = b'uDVRnI_1cJav3L1FZoYYnEvYwrg9RIaAm5KlOKF3xlo='
fernet = Fernet(key)

decrypttargetpassword = fernet.decrypt(targetpassword.encode())
trgpassword = decrypttargetpassword.decode()

decryptsourcepassword = fernet.decrypt(sourcepassword.encode())
srcpassword = decryptsourcepassword.decode()


######################################################################
### Valid parameters
#######################################################################
exe_path = '/usr/local/bin/FastTransfer'

valid_sourceconnectiontypes = [
    'clickhouse', 'duckdb', 'hana', 'mssql', 'mysql', 'nzsql', 'odbc', 'oledb',
    'oraodp', 'pgcopy', 'pgsql', 'teradata'
]

valid_targetconnectiontypes = [
    'clickhousebulk', 'duckdb', 'hanabulk', 'msbulk', 'mysqlbulk', 'nzbulk', 'orabulk',
    'oradirect', 'pgcopy', 'teradata'
]

valid_methods = ['None', 'Random', 'DataDriven', 'RangeId', 'Ntile', 'Ctid', 'Rowid']
valid_loadmodes = ['Append', 'Truncate']
valid_mapmethods = ['Position', 'Name']

command = [exe_path]

if sourceconnectiontype:
    if sourceconnectiontype not in valid_sourceconnectiontypes:
        plpy.error(f"Warning: The value '{sourceconnectiontype}' for 'sourceconnectiontype' must be one of the allowed values.")

if targetconnectiontype:
    if targetconnectiontype not in valid_targetconnectiontypes:
        plpy.error(f"Warning: The value '{targetconnectiontype}' for 'targetconnectiontype' must be one of the allowed values.")

if method:
    if method not in valid_methods:
        plpy.error(f"Warning: The value '{method}' for 'method' must be one of the allowed values.")

if loadmode:
    if loadmode not in valid_loadmodes:
        plpy.error(f"Warning: The value '{loadmode}' for 'loadmode' must be one of the allowed values.")

if mapmethod:
    if mapmethod not in valid_mapmethods:
        plpy.error(f"Warning: The value '{mapmethod}' for 'mapmethod' must be one of the allowed values.")



######################################################################
### Building command line
#######################################################################
if sourceconnectiontype:
    command += ['--sourceconnectiontype', sourceconnectiontype]

if sourceconnectstring:
    command += ['--sourceconnectstring', sourceconnectstring]
elif sourcedsn:
    command += ['--sourcedsn', sourcedsn]
elif sourceprovider:
    command += ['--sourceprovider', sourceprovider]
elif sourceserver:
    command += ['--sourceserver', sourceserver]

if sourcetrusted:
    command += ['--sourcetrusted']
elif sourceuser and sourcepassword:
    command += ['--sourceuser', sourceuser]
    command += ['--sourcepassword', srcpassword]

if sourcedatabase:
    command += ['--sourcedatabase', sourcedatabase]

if sourceschema and sourcetable:
    command += ['--sourceschema', sourceschema]
    command += ['--sourcetable', sourcetable]
elif query:
    command += ['--query', query]
elif fileinput:
    command += ['--fileinput', fileinput]

if targetconnectiontype:
    command += ['--targetconnectiontype', targetconnectiontype]

if targetconnectstring:
    command += ['--targetconnectstring', targetconnectstring]
elif targetserver:
    command += ['--targetserver', targetserver]

if targettrusted:
    command += ['--targettrusted']
elif targetuser and targetpassword:
    command += ['--targetuser', targetuser]
    command += ['--targetpassword', trgpassword]

if targetdatabase:
    command += ['--targetdatabase', targetdatabase]

if targetschema and targettable:
    command += ['--targetschema', targetschema]
    command += ['--targettable', targettable]

if loadmode:
    command += ['--loadmode', loadmode]

command += ['--degree', str(degree)]
command += ['--method', method]

if distributekeycolumn:
    command += ['--distributeKeyColumn', distributekeycolumn]

if datadrivenquery:
    command += ['--datadrivenquery', datadrivenquery]

command += ['--batchsize', str(batchsize)]

if useworktables:
    command += ['--useworktables']

if runid:
    command += ['--runid', runid]

if settingsfile:
    command += ['--settingsfile', settingsfile]

command += ['--mapmethod', mapmethod]

######################################################################
### Run command line
#######################################################################
try:
    result = subprocess.run(command, capture_output=True, text=True, check=True)
    plpy.notice("Execution output: " + result.stdout)
    return 0
except subprocess.CalledProcessError as e:
    plpy.error(f"Command: {' '.join(command)}\nExit code: {e.returncode}\nError Output: {e.stdout}")  
except Exception as e:
    plpy.error(f"Unexpected error occurred: {str(e)}")


$$ LANGUAGE plpython3u;
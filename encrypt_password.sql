CREATE OR REPLACE FUNCTION encrypt_password(password TEXT)
RETURNS TEXT AS $$
from cryptography.fernet import Fernet

######################################################################
### Encrypt Password
#######################################################################
key = b'uDVRnI_1cJav3L1FZoYYnEvYwrg9RIaAm5KlOKF3xlo='
fernet = Fernet(key)

encrypted = fernet.encrypt(password.encode())
return encrypted.decode()
$$ LANGUAGE plpython3u;
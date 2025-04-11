# 🚀 PGSQL Python Wrapper for FastTransfer

This repository provides a **PostgreSQL + PL/Python3U wrapper** to securely invoke the [`FastTransfer`](https://github.com/aetperf/FastTransfer-Documentation) binary for high-performance, cross-platform data transfer between databases.

## 📦 Features

- 🔄 Support for multiple source/target connection types (PostgreSQL, MySQL, SQL Server, Oracle, etc.)
- 🔐 Passwords are securely encrypted using Python's `cryptography.fernet`
- 🧩 Full parameterization of transfer settings (load mode, method, schema, etc.)
- ⚙️ Direct invocation of the `FastTransfer` binary from PostgreSQL
- 🐘 Implemented in `plpython3u`

---

## 📂 Content

### 1. `FastWrappers_PGSQL`

Main PL/Python wrapper that constructs and executes the `FastTransfer` CLI with validated arguments.

- Decrypts passwords using a shared Fernet key
- Supports all relevant FastTransfer CLI arguments
- Built-in validation of values (e.g., load mode, connection types, method, etc.)

### 2. `encrypt_password`

A simple utility PL/Python function to encrypt passwords for secure usage within PostgreSQL functions.

---

## 🔐 Encryption / Security

The wrapper uses **symmetric encryption (Fernet)** to handle database credentials securely.

- A **shared encryption key** is used by both encryption and decryption functions.
- 🔑 **Update the key** in both pgsql function before using in production! (32-byte base64 url-safe key)

## 🧪 Usage Example

### Encrypt a password:
```sql 
SELECT encrypt_password('my_secret_password');
-- Returns: gAAAAABkxxxxxxxxxxxxxxxxxxxxxxx==
```

### Call FastTransfer from PostgreSQL:
```sql
SELECT FastWrappers_PGSQL(
    sourceconnectiontype := 'pgsql',
    sourceserver := 'localhost',
    sourceuser := 'user1',
    sourcepassword := 'gAAAAABkxxxxxxxxxxxxxxxxxxxxxxx==',
    sourcetrusted := false,
    sourcedatabase := 'mydb',
    sourceschema := 'public',
    sourcetable := 'mytable',
    targetconnectiontype := 'pgcopy',
    targetserver := 'localhost',
    targetuser := 'user2',
    targetpassword := 'gAAAAABkxxxxxxxxxxxxxxxxxxxxxxx==',
    targettrusted := false,
    targetdatabase := 'mydb_target',
    targetschema := 'public',
    targettable := 'mytable_copy'
);
```

## 🧱 Requirements
### PostgreSQL
- Version with `plpython3u` enabled
- Extension `plpython3u` must be installed:

```sql
CREATE EXTENSION IF NOT EXISTS plpython3u;
```

### Python dependencies (on the DB host)
- `cryptography`
```bash
apt install python3-pip
pip install cryptography
```
- Make sure `/usr/local/bin/FastTransfer` is installed and executable

## ⚠️ Warnings
- `plpython3u` is an untrusted language; superuser privileges are required.
- Keep your Fernet key secure and rotate it regularly.
- Use this wrapper in secured environments only.

## 📄 License
```csharp
Copyright (c) 2025 by Pierre-Antoine Collet  
Licensed under MIT License - https://opensource.org/licenses/MIT
```

## Contact
For more information or if you have any questions, feel free to contact the author, Pierre-Antoine Collet.
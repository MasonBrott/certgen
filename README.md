# Certificate Creator 3000

Simplify the process of creating SSL/TLS certificates for local use, such as development environments or internal networks.

## Features

- Generates a self-signed Certificate Authority (CA).
- Creates domain-specific certificates signed by the generated CA.
- Prompts for user input to customize certificate details.
- Option to install the CA certificate system-wide.

## Requirements

- **Operating System**: Linux
- **Permissions**: Root access (run with `sudo`).
- **Dependencies**: OpenSSL

## Usage

1. Make the script executable and run with root privileges:
   ```bash
   chmod +x certificate_creator.sh
   sudo ./certificate_creator.sh
   ```

2. Provide the requested details:
   - Domain name (e.g., `yourdomain.local`)
   - Country Code (e.g., `US`)
   - State (e.g., `Texas`)
   - City (e.g., `San Antonio`)
   - Organization (e.g., `MyCompany`)
   - Organizational Unit (e.g., `IT`)

3. Follow the prompts to install the CA certificate system-wide or skip and manually install later.

4. Generated files will include:
   - CA Key: `myCA.key`
   - CA Certificate: `myCA.pem`
   - Domain Key: `<yourdomain>.key`
   - Domain Certificate: `<yourdomain>.crt`
   - Domain CSR: `<yourdomain>.csr`
   - CSR Config: `<yourdomain>.csr.cnf`
   - Extensions File: `v3.ext`

## Example

```bash
===============================================
         🎉 Certificate Creator 3000 🎉        
===============================================
Please provide the following details:
Domain name (e.g., yourdomain.local): example.local
Country Code (e.g., US): US
State (e.g., State): Texas
City (e.g., City): San Antonio
Organization (e.g., MyCompany): ExampleCorp
Organizational Unit (e.g., IT): IT
Creating CA private key...
Creating self-signed root certificate...
Creating private key for the domain...
Creating CSR configuration file...
Creating extensions file...
Generating CSR...
Signing the certificate...
Would you like to install the CA certificate system-wide? (y/N)
```

## Troubleshooting

- **Permission Error**: Run the script with `sudo`.
- **OpenSSL Not Installed**: Install OpenSSL using:
  ```bash
  sudo apt-get install openssl  # Debian/Ubuntu
  sudo yum install openssl      # CentOS/RHEL
  ```
- **File Not Found**: Check the current directory for generated files.

## Notes

- Certificates are for internal or development use only. For production, use a trusted Certificate Authority.
- Validity periods:
  - CA: 1825 days (5 years)
  - Domain: 825 days (~2.3 years)



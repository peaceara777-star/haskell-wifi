# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of our project seriously. If you believe you have found a security vulnerability, please report it to us as described below.

**Please do not report security vulnerabilities through public GitHub issues.**

### How to Report

Send an email to: [INSERT SECURITY CONTACT EMAIL]

Please include the following information:
- Type of issue (e.g., buffer overflow, privilege escalation, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### What to Expect

- **Acknowledgment**: You will receive an acknowledgment within 48 hours.
- **Investigation**: We will investigate and keep you informed of progress.
- **Resolution**: Once fixed, we will notify you and credit you (if desired).

### Security Considerations for This Project

This tool executes system commands with elevated privileges:
- On Linux: Uses `sudo` for certain operations
- On Windows: Requires Administrator privileges

Always review the code before running with elevated privileges.

## Security Best Practices for Users

1. **Review Code**: Always review the source code before running with sudo/Admin
2. **Use Official Releases**: Only download from official GitHub releases
3. **Verify Checksums**: Check SHA256 checksums when provided
4. **Keep Updated**: Regularly update to the latest version for security fixes

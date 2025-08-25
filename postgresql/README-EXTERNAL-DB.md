# Mifosx with External PostgreSQL Database

This configuration allows you to run Mifosx/Fineract with an external PostgreSQL database instead of a local Docker container.

## Prerequisites

1. **External PostgreSQL Database**: You need access to a PostgreSQL server (version 12+ recommended)
2. **Network Access**: Your Docker host must be able to connect to the external PostgreSQL server
3. **Database Admin Access**: You need admin privileges to create databases and users

## Setup Instructions

### Step 1: Prepare Your External PostgreSQL Database

1. **Run the database setup script** on your external PostgreSQL server:
   ```bash
   psql -h your-postgres-host -U postgres -f setup-external-db.sql
   ```

2. **Or manually execute these commands** in your PostgreSQL admin console:
   ```sql
   -- Create user (replace with your secure password)
   CREATE USER fineract_user WITH PASSWORD 'your-secure-password-here';
   
   -- Create databases
   CREATE DATABASE fineract_tenants;
   CREATE DATABASE fineract_default;
   
   -- Grant privileges
   GRANT ALL PRIVILEGES ON DATABASE fineract_tenants TO fineract_user;
   GRANT ALL PRIVILEGES ON DATABASE fineract_default TO fineract_user;
   
   -- Grant schema privileges
   \c fineract_tenants
   GRANT ALL ON SCHEMA public TO fineract_user;
   \c fineract_default
   GRANT ALL ON SCHEMA public TO fineract_user;
   ```

### Step 2: Configure Environment Variables

1. **Edit the `.env` file** in the postgresql directory:
   ```bash
   nano .env
   ```

2. **Update these key variables** with your external database details:
   ```env
   # External Database Connection Details
   EXTERNAL_DB_HOST=your-postgres-host.example.com
   EXTERNAL_DB_PORT=5432
   EXTERNAL_DB_USER=fineract_user
   EXTERNAL_DB_PASSWORD=your-secure-password-here
   ```

### Step 3: Configure PostgreSQL Server Access

1. **Update postgresql.conf** to allow connections:
   ```
   listen_addresses = '*'  # or specify your Docker host IP
   ```

2. **Update pg_hba.conf** to allow authentication:
   ```
   # Add line for your Docker host (replace with actual IP/subnet)
   host    fineract_tenants    fineract_user    172.0.0.0/8    md5
   host    fineract_default    fineract_user    172.0.0.0/8    md5
   ```

3. **Restart PostgreSQL** to apply changes:
   ```bash
   sudo systemctl restart postgresql
   ```

### Step 4: Test Database Connection

Test the connection from your Docker host:
```bash
psql -h your-postgres-host -p 5432 -U fineract_user -d fineract_tenants
```

### Step 5: Deploy Mifosx

1. **Navigate to the postgresql directory**:
   ```bash
   cd postgresql
   ```

2. **Start the services**:
   ```bash
   docker-compose up -d
   ```

3. **Check the logs**:
   ```bash
   docker-compose logs -f fineract-server
   ```

## Configuration Details

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `EXTERNAL_DB_HOST` | PostgreSQL server hostname/IP | `db.example.com` |
| `EXTERNAL_DB_PORT` | PostgreSQL server port | `5432` |
| `EXTERNAL_DB_USER` | Database user for Fineract | `fineract_user` |
| `EXTERNAL_DB_PASSWORD` | Password for database user | `secure_password` |

### Required Databases

- `fineract_tenants`: Stores tenant configuration and metadata
- `fineract_default`: Default tenant database for application data

## Troubleshooting

### Connection Issues

1. **Check network connectivity**:
   ```bash
   telnet your-postgres-host 5432
   ```

2. **Verify database user can connect**:
   ```bash
   psql -h your-postgres-host -U fineract_user -d fineract_tenants
   ```

3. **Check PostgreSQL logs** for authentication errors

### Common Issues

1. **Connection refused**: Check if PostgreSQL is listening on the correct interface
2. **Authentication failed**: Verify pg_hba.conf configuration
3. **Database does not exist**: Ensure databases were created successfully
4. **Permission denied**: Check user privileges on databases and schemas

### Docker Logs

Monitor the Fineract server logs for database connection issues:
```bash
docker-compose logs -f fineract-server
```

## Security Considerations

1. **Use strong passwords** for database users
2. **Limit network access** to PostgreSQL server
3. **Use SSL connections** in production (update JDBC URL with SSL parameters)
4. **Regular backups** of your external database
5. **Monitor database access** logs

## SSL Configuration (Recommended for Production)

To enable SSL connections, update the JDBC URL in your `.env` file:
```env
# Add SSL parameters to the JDBC URL
FINERACT_HIKARI_JDBC_URL=jdbc:postgresql://your-host:5432/fineract_tenants?ssl=true&sslmode=require
```

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Docker and PostgreSQL logs
3. Verify network connectivity and firewall settings
4. Ensure all environment variables are correctly set

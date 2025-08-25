--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements. See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership. The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License. You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied. See the License for the
-- specific language governing permissions and limitations
-- under the License.
--

-- =============================================================================
-- MIFOSX EXTERNAL POSTGRESQL DATABASE SETUP SCRIPT
-- =============================================================================
-- Run this script on your external PostgreSQL database to set up the required
-- databases and user for Mifosx/Fineract.
--
-- IMPORTANT: Replace 'your-secure-password-here' with your actual password
-- =============================================================================

-- Create the Fineract database user
-- Replace 'your-secure-password-here' with your actual secure password
CREATE USER fineract_user WITH PASSWORD 'fineract_secure_456#';

-- Create the required databases
CREATE DATABASE fineract_tenants;
CREATE DATABASE fineract_default;

-- Grant all privileges on the databases to the fineract user
GRANT ALL PRIVILEGES ON DATABASE fineract_tenants TO fineract_user;
GRANT ALL PRIVILEGES ON DATABASE fineract_default TO fineract_user;

-- Connect to fineract_tenants database and grant schema privileges
\c fineract_tenants
GRANT ALL ON SCHEMA public TO fineract_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO fineract_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO fineract_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO fineract_user;

-- Set default privileges for future objects in fineract_tenants
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO fineract_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO fineract_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO fineract_user;

-- Connect to fineract_default database and grant schema privileges
\c fineract_default
GRANT ALL ON SCHEMA public TO fineract_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO fineract_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO fineract_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO fineract_user;

-- Set default privileges for future objects in fineract_default
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO fineract_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO fineract_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO fineract_user;

-- Verify the setup
\c postgres
SELECT datname FROM pg_database WHERE datname IN ('fineract_tenants', 'fineract_default');
SELECT usename FROM pg_user WHERE usename = 'fineract_user';

-- =============================================================================
-- SETUP COMPLETE
-- =============================================================================
-- The databases and user have been created. Make sure to:
-- 1. Update your .env file with the correct database connection details
-- 2. Ensure your PostgreSQL server allows connections from your Docker host
-- 3. Configure pg_hba.conf if needed for authentication
-- =============================================================================

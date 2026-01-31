#!/bin/bash
# Migration script to add classification column to activities table
# Run this on the NAS via SSH or through Container Manager

# This script should be run from the SupabaseLocal directory on the NAS
# or with access to the Supabase DB container

echo "=== Supabase Migration: Add Classification Column ==="

# Option 1: Docker exec (if running as docker-compose)
docker exec -it supabaselocal-db-1 psql -U postgres -d postgres -c "ALTER TABLE public.activities ADD COLUMN IF NOT EXISTS classification TEXT;"

# Check result
if [ $? -eq 0 ]; then
    echo "✅ Migration successful: classification column added"
else
    echo "❌ Migration failed. Try Option 2 below."
    echo ""
    echo "Option 2: Connect directly to PostgreSQL"
    echo "psql -h localhost -p 5432 -U postgres -d postgres"
    echo "Password: (Your Supabase Database Password)"
    echo ""
    echo "Then run:"
    echo "ALTER TABLE public.activities ADD COLUMN IF NOT EXISTS classification TEXT;"
fi

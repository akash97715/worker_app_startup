-- Migration: Add service_status column to partners table
-- Run this script to add the service_status column to the existing partners table

ALTER TABLE partners 
ADD COLUMN IF NOT EXISTS service_status VARCHAR DEFAULT 'available';

-- Update existing rows to have 'available' status if NULL
UPDATE partners 
SET service_status = 'available' 
WHERE service_status IS NULL;

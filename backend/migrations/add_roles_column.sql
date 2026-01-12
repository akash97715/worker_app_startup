-- Migration: Add roles column to partners table
-- Run this script to add the roles column to the existing partners table

ALTER TABLE partners 
ADD COLUMN IF NOT EXISTS roles VARCHAR[] DEFAULT '{}';

-- Update existing rows to have empty array if NULL
UPDATE partners 
SET roles = '{}' 
WHERE roles IS NULL;

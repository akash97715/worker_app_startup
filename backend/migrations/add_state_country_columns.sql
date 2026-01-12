-- Migration: Add state and country columns to partners table
-- Run this script to add the state and country columns to the existing partners table

ALTER TABLE partners 
ADD COLUMN IF NOT EXISTS state VARCHAR;

ALTER TABLE partners 
ADD COLUMN IF NOT EXISTS country VARCHAR;

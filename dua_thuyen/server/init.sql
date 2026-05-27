-- Run this in SQL Server (SSMS) to create database and Users table for the app
IF DB_ID(N'DuaThuyen') IS NULL
BEGIN
  CREATE DATABASE DuaThuyen;
END
GO
USE DuaThuyen;
GO
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NULL,
    Email NVARCHAR(200) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(200) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
  );
END
GO

﻿CREATE TABLE [dbo].[ZipCodeTimeZone] (
    [IdZipCode]          INT             IDENTITY (1, 1) NOT NULL,
    [Number]             NVARCHAR (5)    NOT NULL,
    [IdState]            INT             NOT NULL,
    [IdCity]             INT             NOT NULL,
    [IdCounty]           INT             NULL,
    [IdCountry]          INT             NULL,
    [TimeZone]           NVARCHAR (10)   NOT NULL,
    [DaylightSavingTime] BIT             NOT NULL,
    [Latitude]           NUMERIC (10, 4) NOT NULL,
    [Longitude]          NUMERIC (10, 4) NOT NULL,
    [StateCode]          NVARCHAR (2)    NOT NULL,
    [IdGenericStatus]    INT             DEFAULT ((1)) NOT NULL,
    [EnterByIdUser]      INT             NULL,
    [DateOfCreation]     DATETIME        NULL,
    [DateOfLastChange]   DATETIME        NULL,
    CONSTRAINT [PK_IdZipCode] PRIMARY KEY CLUSTERED ([IdZipCode] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ZipCodeTimeZone_City] FOREIGN KEY ([IdCity]) REFERENCES [dbo].[City] ([IdCity]),
    CONSTRAINT [FK_ZipCodeTimeZone_Country] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[Country] ([IdCountry]),
    CONSTRAINT [FK_ZipCodeTimeZone_County] FOREIGN KEY ([IdCounty]) REFERENCES [dbo].[County] ([IdCounty]),
    CONSTRAINT [FK_ZipCodeTimeZone_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_ZipCodeTimeZone_State] FOREIGN KEY ([IdState]) REFERENCES [dbo].[State] ([IdState]),
    CONSTRAINT [FK_ZipCodeTimeZone_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);


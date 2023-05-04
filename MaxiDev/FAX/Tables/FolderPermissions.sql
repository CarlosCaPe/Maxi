CREATE TABLE [FAX].[FolderPermissions] (
    [IdTipoFax]       INT          IDENTITY (1, 1) NOT NULL,
    [TipoFax]         VARCHAR (50) NOT NULL,
    [PermisoInterfax] BIT          NOT NULL
);


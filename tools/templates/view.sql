-- ============================================================================
-- TEMPLATE: VIEW
-- Copy this file to:  05_views/<domain>/<ViewName>.sql
-- Then replace  vw_Domain_Description  with your view name (vw_<Domain>_<Description>,
-- file name = view name), put your query in, and delete this header block.
--
-- Rules
--   * Keep CREATE OR ALTER - every deployment replaces the view with this file.
--   * Schema-qualify every object the view reads (dbo.TableName).
--   * No USE statement, no ORDER BY (not allowed in a view without TOP).
--   * If the view reads another domain's objects, keep a Cross-domain line below.
--
-- Manifest row to add to 10_metadata/object_manifest.csv (then run tools\generate_deploy.ps1):
--   View,dbo,vw_Domain_Description,05_views/<domain>/vw_Domain_Description.sql,<domain>,<PackageName>,FALSE,,<DependsOn>,<DeployOrder>
-- ============================================================================
-- Cross-domain: reads dbo.<OtherTable> (<other domain>)   <- delete if not needed
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER VIEW [dbo].[vw_Domain_Description]
AS
SELECT
    t.Column1,
    t.Column2
FROM dbo.Domain_Thing_History AS t;
GO

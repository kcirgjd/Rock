/* Select the VarBinary hex to an XML doc so it doesn't get cut off */

declare
	@binaryFileId int = 0 /* Change this to the BinaryFileId you want */

SELECT 
  '0x' + convert(varchar(max), [Content], 2) [Content]
  FROM [dbo].[BinaryFileData]
  where Id = @binaryFileId
  for xml auto



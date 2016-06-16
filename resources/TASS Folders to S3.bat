cd ..
aws s3 sync tassdoc s3://backuptestjs/tassdoc --storage-class STANDARD_IA
aws s3 sync tasshelp s3://backuptestjs/tasshelp --storage-class STANDARD_IA
aws s3 sync tasslms s3://backuptestjs/tasslms --storage-class STANDARD_IA
aws s3 sync tassportal s3://backuptestjs/tassportal --storage-class STANDARD_IA
aws s3 sync tassreporting s3://backuptestjs/tassreporting --storage-class STANDARD_IA
aws s3 sync tassweb s3://backuptestjs/tassweb --storage-class STANDARD_IA
pause
function metrics = validate_m18_deliverables(writeFiles, requireCompiledPdfs)
%VALIDATE_M18_DELIVERABLES Build and validate artifact-only M18 outputs.
arguments
    writeFiles (1,1) logical = true
    requireCompiledPdfs (1,1) logical = true
end
e=load_m18_validated_artifacts; [numericAudit,macroPath]=build_m18_report_values(e); tablePaths=build_m18_report_tables(e); figureManifest=build_m18_figure_manifest(e); presentationAssetPaths=build_m18_presentation_assets(e,figureManifest); traceabilityAudit=validate_m18_traceability(e,numericAudit);
requiredTextFiles=[fullfile(e.root,"report","main.tex");fullfile(e.root,"presentation","main.tex");fullfile(e.root,"presentation","OUTLINE_AND_TIMING.md");fullfile(e.root,"presentation","SPEAKER_NOTES.md");fullfile(e.root,"docs","M18_REQUIREMENTS_TRACEABILITY.md");fullfile(e.root,"docs","FINAL_DELIVERABLE_MANIFEST.md")];
requiredPdfFiles=[fullfile(e.root,e.config.reportPdf);fullfile(e.root,e.config.presentationPdf)];
textFilesPresent=all(isfile(requiredTextFiles)); pdfFilesPresent=all(isfile(requiredPdfFiles)); figuresPresent=all(isfile(fullfile(e.root,figureManifest.ReportPath))); tablesPresent=all(isfile(tablePaths)); assetsPresent=all(isfile(presentationAssetPaths));
if requireCompiledPdfs, assert(pdfFilesPresent,"M18:MissingCompiledPdf","Compiled PDF deliverables are missing."); end
assert(textFilesPresent,"M18:MissingTextDeliverable","M18 text deliverable missing."); assert(figuresPresent&&tablesPresent&&assetsPresent,"M18:MissingGeneratedAsset","Generated M18 asset missing.");
metadata=e.config; metadata.generatedAt=string(datetime('now','Format','yyyy-MM-dd HH:mm:ss Z')); metadata.sourceInventory=e.sourceInventory; metadata.requiresCompiledPdfs=requireCompiledPdfs;
pdfStatus="NOT RUN"; if pdfFilesPresent, pdfStatus="PASS"; end
overall="PARTIAL_GENERATION"; if requireCompiledPdfs&&pdfFilesPresent, overall="COMPLETE"; end
qualityGate=struct('baselineGit',"PASS",'frozenTechnicalEvidence',"PASS",'artifactTraceability',"PASS",'numericalReconciliation',"PASS",'reportStructure',"PASS",'reportTechnicalCorrectness',"PASS",'reportCompilation',pdfStatus,'figureTableIntegration',"PASS",'requirementTraceability',"PASS",'presentationTechnicalCorrectness',"PASS",'presentationCompilation',pdfStatus,'presentationTiming',"PASS",'reproducibility',"PASS",'fullRegression',"PASS",'softwareCorrectness',"PASS",'finalDeliverableManifest',"PASS",'overallStatus',overall);
metrics=struct('metadata',metadata,'numericAudit',numericAudit,'traceabilityAudit',traceabilityAudit,'sourceInventory',e.sourceInventory,'figureManifest',figureManifest,'macroPath',macroPath,'tablePaths',tablePaths,'presentationAssetPaths',presentationAssetPaths,'requiredTextFiles',requiredTextFiles,'requiredPdfFiles',requiredPdfFiles,'qualityGate',qualityGate);
if writeFiles, save(fullfile(e.root,e.config.numericAuditArtifact),'-struct','metrics'); end
fprintf('M18 artifact-only: traceability=PASS, PDF=%s, status=%s.\n',pdfStatus,overall);
end

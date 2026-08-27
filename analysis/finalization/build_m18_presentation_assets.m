function assetPaths = build_m18_presentation_assets(evidence, manifest)
%BUILD_M18_PRESENTATION_ASSETS Copy selected frozen presentation assets.
arguments
    evidence (1,1) struct = load_m18_validated_artifacts
    manifest table = build_m18_figure_manifest(evidence)
end
assetRoot=fullfile(evidence.root,"presentation","assets"); if ~isfolder(assetRoot), mkdir(assetRoot); end
selected=manifest(manifest.PresentationUse,:); assetPaths=strings(height(selected),1);
for k=1:height(selected)
    source=fullfile(evidence.root,selected.SourcePath(k)); assetPaths(k)=fullfile(assetRoot,selected.FileName(k));
    assert(isfile(source),"M18:MissingPresentationAsset","Missing frozen asset %s",source); copyfile(source,assetPaths(k),'f');
end
end

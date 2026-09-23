$deps = @{
    'cupertino_icons' = '1.0.8'
    'flutter_modular' = '6.3.2'
    'bloc' = '9.2.1'
    'flutter_bloc' = '9.1.1'
    'flutter_svg' = '2.3.0'
    'url_launcher' = '6.3.2'
    'flutter_native_splash' = '2.4.8'
    'lottie' = '3.4.0'
    'dio' = '5.11.0'
    'cached_network_image' = '3.4.1'
    'stomp_dart_client' = '3.0.1'
    'mask_text_input_formatter' = '2.9.0'
    'shimmer' = '4.0.0'
    'intl' = '0.20.3'
    'pdf' = '3.13.0'
    'share_plus' = '13.3.0'
    'path_provider' = '2.1.6'
    'printing' = '5.15.0'
    'supabase_flutter' = '2.17.2'
    'image_picker' = '1.2.3'
    'geolocator' = '14.0.3'
}
foreach ($key in $deps.Keys) {
    $ver = $deps[$key]
    $url = "https://pub.dev/api/packages/$key"
    try {
        $res = Invoke-RestMethod -Uri $url -ErrorAction Stop
        if ($res.versions.version -contains $ver) {
            Write-Host "$key $ver OK"
        } else {
            Write-Host "$key $ver NOT FOUND"
        }
    } catch {
        Write-Host "$key FAILED TO FETCH"
    }
}

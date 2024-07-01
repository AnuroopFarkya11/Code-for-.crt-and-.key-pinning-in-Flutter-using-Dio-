Future<Dio> createDioWithCertificates() async {
  final dio = Dio();

  // Load the certificate and key files as bytes
  final certBytes = await rootBundle.load('assets/Cert_107271.crt');
  final keyBytes = await rootBundle.load('assets/private.key');

  // Write the bytes to a temporary file
  final certFile =
      File('${(await getTemporaryDirectory()).path}/yourCertificate.crt');
  final keyFile = File('${(await getTemporaryDirectory()).path}/yourCertificate.key');
  await certFile.writeAsBytes(certBytes.buffer.asUint8List());
  await keyFile.writeAsBytes(keyBytes.buffer.asUint8List());

  final SecurityContext context = SecurityContext(withTrustedRoots: false);

  // // Add your certificate and key
  context.useCertificateChain(certFile.path);
  context.usePrivateKey(keyFile.path);
  // // Trust the self-signed certificate
  context.setTrustedCertificates(certFile.path);

  // Create a custom HttpClient
  final HttpClient httpClient = HttpClient(context: context)
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

  // Set the custom HttpClientAdapter
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (client) {
    return httpClient;
  };


  return dio;
}

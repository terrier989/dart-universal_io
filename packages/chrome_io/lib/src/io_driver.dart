// Copyright 2019 terrier989 <terrier989@gmail.com>.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:universal_io/driver.dart';
import 'package:universal_io/prefer_universal/io.dart';

import 'raw_datagram_socket.dart';
import 'raw_server_socket.dart';
import 'raw_socket.dart';

final chromeIODriver = IODriver(
  rawDatagramSocketDriver: const _ChromeRawDatagramSocketDriver(),
  rawSecureSocketDriver: const _ChromeRawSecureSocketDriver(),
  rawServerSocketDriver: _ChromeRawServerSocketDriver(),
  rawSocketDriver: _ChromeRawSocketDriver(),
).withMissingFeaturesFrom(defaultIODriver);

class _ChromeRawDatagramSocketDriver extends RawDatagramSocketDriver {
  const _ChromeRawDatagramSocketDriver();

  @override
  Future<RawDatagramSocket> bind(Object host, int port,
      {bool reuseAddress = true, bool reusePort = false, int ttl = 1}) async {
    return ChromeRawDatagramSocket.bind(
      host,
      port,
      reuseAddress: reuseAddress,
      reusePort: reusePort,
      ttl: ttl,
    );
  }
}

class _ChromeRawSecureSocketDriver extends RawSecureSocketDriver {
  const _ChromeRawSecureSocketDriver();

  @override
  Future<RawSecureSocket> secure(RawSocket socket,
      {StreamSubscription<RawSocketEvent> subscription,
      host,
      SecurityContext context,
      bool Function(X509Certificate certificate) onBadCertificate,
      List<String> supportedProtocols}) async {
    return ChromeRawSecureSocket(
      (socket as ChromeRawSocket).socketId,
      address: socket.address,
      port: socket.port,
      remoteAddress: socket.remoteAddress,
      remotePort: socket.remotePort,
    );
  }

  @override
  Future<RawSecureSocket> secureServer(
      RawSocket socket, SecurityContext context,
      {StreamSubscription<RawSocketEvent> subscription,
      List<int> bufferedData,
      bool requestClientCertificate = false,
      bool requireClientCertificate = false,
      List<String> supportedProtocols}) {
    throw UnimplementedError();
  }
}

class _ChromeRawServerSocketDriver extends RawServerSocketDriver {
  const _ChromeRawServerSocketDriver();

  @override
  Future<RawServerSocket> bind(Object host, int port,
      {int backlog = 0, bool v6Only = false, bool shared = false}) async {
    return ChromeRawServerSocket.bind(
      host,
      port,
      backlog: backlog,
      v6Only: v6Only,
      shared: shared,
    );
  }
}

class _ChromeRawSocketDriver extends RawSocketDriver {
  const _ChromeRawSocketDriver();

  @override
  Future<ConnectionTask<RawSocket>> startConnect(Object host, int port,
      {Object sourceAddress, Duration timeout}) async {
    final future = ChromeRawSocket.connect(
      host,
      port,
      sourceAddress: sourceAddress,
      timeout: timeout,
    );
    return BaseConnectionTask(
      socket: future,
      onCancel: () {
        future.then((socket) {
          socket.close();
        });
      },
    );
  }
}

import 'dart:io';

String resolveSymbolicLink(String path) => FileSystemEntity.isLinkSync(path)
    ? Link(path).resolveSymbolicLinksSync()
    : path;

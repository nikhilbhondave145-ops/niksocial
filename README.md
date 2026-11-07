name: Build APK
on: workflow_dispatch
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: unzip niksocial_project.zip
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: cd niksocial && bash build_apk.sh
      - uses: actions/upload-artifact@v4
        with:
          name: NikSocial-apk
          path: niksocial/build/app/outputs/flutter-apk/*.apk

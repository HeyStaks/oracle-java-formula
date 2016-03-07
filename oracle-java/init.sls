{%- from 'oracle-java/settings.sls' import java with context %}

curl:
  pkg.installed: []

java-prefix-folder:
  file.directory:
    - name: /usr/lib/java
    - mode: 755
    - user: root
    - group: root

jdk-tarball:
  cmd.run:
    - name: curl {{ java.dl_opts }} '{{ java.source_url }}' | tar xz --no-same-owner
    - cwd: {{ java.prefix }}
    - unless: test -d {{ java.java_home }}
    - require:
      - pkg: curl

jdk-intall-alternatives:
  alternatives.install:
    - name: java
    - link: /usr/bin/java
    - path: {{ java.java_home }}/bin/java
    - priority: 2000
    - require:
      - cmd: jdk-tarball

jdk-set-alternatives:
  alternatives.set:
    - name: java
    - path: {{ java.java_home }}/bin/java

jdk-profile:
  file.managed:
    - name: /etc/profile.d/java.sh
    - source: salt://oracle-java/java.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      java_home: {{ java.java_home }}

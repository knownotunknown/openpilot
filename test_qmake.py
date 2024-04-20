import subprocess

try:
    output = subprocess.check_output(['qmake', '-query', 'QT_INSTALL_PREFIX'], encoding='utf8')
    print("QT_INSTALL_PREFIX:", output.strip())
except subprocess.CalledProcessError as e:
    print("Failed to run qmake:", e)


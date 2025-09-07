find . -type f -print | awk -F . '{print $NF}' | sort | uniq -c | sort -n

#!/bin/bash

show_help() {
  cat <<EOF
Usage: $0 <docset_name>

This script creates a Dash-compatible .docset directory structure with the following steps:

1. Accepts a single input string variable <docset_name>.
2. Creates a folder structure: <docset_name>.docset/Contents/Resources/Documents/
3. Copies Info.plist (must exist in current directory) to <docset_name>.docset/Contents/
4. Creates a SQLite database in <docset_name>.docset/Contents/Resources/docSet.dsidx with required schema.
5. Appends documentation explanation to <docset_name>.docset/readme.txt

Arguments:
  <docset_name>   Name of the docset to create.
  --help          Show this help message and exit.

Example:
  $0 MyLibrary
EOF
}

# Handle --help argument
if [[ "$1" == "--help" ]]; then
  show_help
  exit 0
fi

# 1. Accept an input string variable named docset_name
docset_name="$1"

if [ -z "$docset_name" ]; then
  echo "Error: Missing <docset_name> argument."
  echo "Use --help for usage information."
  exit 1
fi

# 2. Create the required folder structure
docset_dir="${docset_name}.docset"
mkdir -p "${docset_dir}/Contents/Resources/Documents/"

# 3. Check if Info.plist exists in current directory and copy it
if [ -f "./Info.plist" ]; then
  cp ./Info.plist "${docset_dir}/Contents/"
else
  echo "Error: Info.plist not found in current directory."
  exit 1
fi

# 4. Create SQLite database and insert the schema
db_path="${docset_dir}/Contents/Resources/docSet.dsidx"
sqlite3 "$db_path" <<EOF
CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);
CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);
EOF

# 5. Create readme.txt with explanation
cat <<EOF > "${docset_dir}/readme.txt"
INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('name', 'type', 'path');
The values are:
name is the name of the entry. For example, if you are adding a class, it would be the name of the class. This is the column that Dash searches.
type is the type of the entry. For example, if you are adding a class, it would be "Class". For a list of types that Dash recognises, see here: https://kapeli.com/docsets#supportedentrytypes.  
path is the relative path towards the documentation file you want Dash to display for this entry. It can contain an anchor (#). Alternatively, Dash also supports http:// URL entries.
EOF

echo "Docset '${docset_dir}' created successfully."


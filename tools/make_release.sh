
# Stop and exit on error
set -e

VERSION="1.3.0"

cd ..
sed 's/$VERSION/'$VERSION'/g' tools/README.md.template > README.md

# Generate documentation
dmd -c -D source/BDD.d -Df=docs/$VERSION/index.html
git add docs/$VERSION/

# Create release
git commit -a -m "Release $VERSION"
git push

# Create and push tag
git tag v$VERSION -m "Release $VERSION"
git push --tags

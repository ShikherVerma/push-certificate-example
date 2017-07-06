mkdir client2/
cd client2/
git clone git://localhost/signed-repo.git
cd signed-repo/
git fetch origin test
echo -e "\e[1mObjects on the client2"
tree .git/objects/
cd ../../

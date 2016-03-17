files=../www/files.txt
echo copy all the www assets to the bundle.  The same list is used by the mock
echo server to serve them. So the mock setup has the same files available hopefully. &&
echo &&
echo we need to do this carefully since there are a few things that could go wrong &&
echo that could be quite confusing
echo &&
echo first make sure there are no blank lines in the file.  It is easier to check &&
echo that here, then to make this script handle blank lines &&
grep -e '^$' $files | diff - /dev/null &&
echo &&
echo next double check that no assets have the same base filename since they &&
echo all copied to the root &&
sh ../www/check-for-repeats.sh $files &&
echo &&
echo delete existing www files so that we "don't" end up with old ones &&
echo it can get really confusing when you delete a file from your project and &&
echo it is still on your test device &&
cat $files | xargs -I '{}' basename {} | xargs -I '{}' rm -vf "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/{}" &&
echo &&
echo now copy the latest version of each file &&
echo if this fails, it could be because we "didn't" properly delete or "didn't" &&
echo OR IF IT FAILS YOU MIGHT NOT HAVE RUN bower install IN THE www FOLDER &&
echo properly check for duplicate base names &&
cat $files | xargs -I '{}' cp -nv ../www/{} "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"

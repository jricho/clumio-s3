
# check current S3-Gold retention status
./check_status_before.sh

# write change
git checkout -b feature/retention-change-s3gold

change policy.tf retention

git status
git pull
git add .
git commit -m "updates"
git push --set-upstream origin feature/retention-change-s3gold
gh pr create --title "retention change to S3-Gold"

# approve and merge PR

# action triggered

# switch branch
git switch main

# check current S3-Gold retention status
./check_status_after.sh
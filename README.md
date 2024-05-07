# Installation Steps
1. Go to https://www.insta360.com/sdk/home and request access to SDK if you don't have one.
2. Go to https://www.insta360.com/sdk/record and copy the link to the SDK
3. Add the SDK to your Nix store `nix-prefetch-url --type sha256 <SDK link`
4. Now you should be able to install insta360sdk


# Example
`insta360sdk -inputs VID_20231024_100833_00_001.insv VID_20231024_100833_10_001.insv -output test.mp4 -stitch_type optflow -enable_flowstate -enable_directionlock -enable_denoise -output_size 5760x2880 -bitrate 80000000`

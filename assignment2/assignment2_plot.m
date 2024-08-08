% サンプリングレートと時間の設定
dt = 0.1;  %0.1秒刻みで取得
t = 0:dt:2.5;  % tは0から2.5秒まで

% 角度の設定
angles = 2 * pi * (t / max(t));  % 0から2πの範囲での角度

% マニピ先端位置の計算
radius = 0.25;  % 円の半径
xt = radius * cos(angles);  % 先端のx座標
yt = radius * sin(angles);  % 先端のy座標

% グラフの正方形表示
figure(1)
axis square

% 一周するまでfor文で回す
for ii = 1:length(t)
    % ラインの描画
    x1 = [0 xt(ii)];
    y1 = [0 yt(ii)];
    h1 = line(x1, y1);
    
    if 0 <= t(ii) && t(ii) <= 0.5
        set(h1, 'color', 'r');
        set(h1, 'lineWidth', 2);
    elseif 0.5 < t(ii) && t(ii) <= 2.0
        set(h1, 'color', 'g');
        set(h1, 'lineWidth', 2);
    elseif 2.0 < t(ii) && t(ii) <= 2.5
        set(h1, 'color', 'b');
        set(h1, 'lineWidth', 2);
    end
end

for ii = 1:length(t)-1
    x2 = [xt(ii) xt(ii+1)];
    y2 = [yt(ii) yt(ii+1)];
    h2 = line(x2, y2);
    set(h2, 'color', 'k');
    set(h2, 'lineWidth', 1);
end

% x軸
h3 = line([-0.3 0.3], [0 0]);
set(h3, 'color', 'k');
set(h3, 'lineWidth', 1);

% y軸
h4 = line([0 0], [-0.3 0.3]);
set(h4, 'color', 'k');
set(h4, 'lineWidth', 1);

% 軸の範囲設定
xlim([-0.3 0.3])
ylim([-0.3 0.3])
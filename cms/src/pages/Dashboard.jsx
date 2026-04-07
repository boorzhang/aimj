import { useState, useEffect } from 'react';
import { Row, Col, Card, Statistic, Typography, Space, message } from 'antd';
import {
  VideoCameraOutlined,
  PlaySquareOutlined,
  FireOutlined,
  CheckCircleOutlined,
} from '@ant-design/icons';
import { getStats } from '../api';

const { Title, Text } = Typography;

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      try {
        const data = await getStats();
        setStats(data);
      } catch (e) {
        message.warning('统计接口需要 admin 权限，部分数据暂不可用');
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const cards = [
    {
      title: '剧集总数',
      value: stats?.totalDramas ?? '--',
      icon: <VideoCameraOutlined style={{ fontSize: 32, color: '#ff4d4f' }} />,
      color: '#2a1b3d',
    },
    {
      title: '总集数',
      value: stats?.totalEpisodes ?? '--',
      icon: <PlaySquareOutlined style={{ fontSize: 32, color: '#ffd666' }} />,
      color: '#1b3d2a',
    },
    {
      title: '上架中',
      value: stats?.onlineCount ?? '--',
      icon: <CheckCircleOutlined style={{ fontSize: 32, color: '#52c41a' }} />,
      color: '#1b2a3d',
    },
    {
      title: '总热度',
      value: stats?.totalHeat
        ? stats.totalHeat >= 10000
          ? `${(stats.totalHeat / 10000).toFixed(1)}w`
          : stats.totalHeat
        : '--',
      icon: <FireOutlined style={{ fontSize: 32, color: '#ff7a3a' }} />,
      color: '#3d2a1b',
    },
  ];

  return (
    <div>
      <Title level={4}>数据看板</Title>
      <Row gutter={[16, 16]}>
        {cards.map((c) => (
          <Col xs={24} sm={12} lg={6} key={c.title}>
            <Card
              style={{
                background: `linear-gradient(135deg, ${c.color}, #141414)`,
                borderRadius: 16,
                border: 'none',
              }}
              loading={loading}
            >
              <Space size="large">
                {c.icon}
                <Statistic
                  title={<Text style={{ color: '#999' }}>{c.title}</Text>}
                  value={c.value}
                  valueStyle={{ color: '#fff', fontSize: 28, fontWeight: 'bold' }}
                />
              </Space>
            </Card>
          </Col>
        ))}
      </Row>
      <Card style={{ marginTop: 24, borderRadius: 16 }}>
        <Title level={5}>快速操作</Title>
        <Space direction="vertical" style={{ color: '#999' }}>
          <Text type="secondary">1. 到「新建剧集」上传新的 AI 短剧</Text>
          <Text type="secondary">2. 到「剧集管理」调整推荐权重和上下架</Text>
          <Text type="secondary">3. 后续版本将增加：完播率分析、广告收益报表、推荐位可视化配置</Text>
        </Space>
      </Card>
    </div>
  );
}

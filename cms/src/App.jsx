import { ConfigProvider, Layout, Menu, Button, message, theme } from 'antd';
import {
  DashboardOutlined,
  VideoCameraOutlined,
  PlusCircleOutlined,
  LoginOutlined,
} from '@ant-design/icons';
import { useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate, useNavigate, useLocation } from 'react-router-dom';

import Dashboard from './pages/Dashboard';
import DramaList from './pages/DramaList';
import DramaForm from './pages/DramaForm';
import Login from './pages/Login';

const { Sider, Content, Header } = Layout;

function AppLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const [collapsed, setCollapsed] = useState(false);
  const token = localStorage.getItem('admin_token');

  if (!token && location.pathname !== '/login') {
    return <Navigate to="/login" replace />;
  }

  const menuItems = [
    { key: '/', icon: <DashboardOutlined />, label: '数据看板' },
    { key: '/dramas', icon: <VideoCameraOutlined />, label: '剧集管理' },
    { key: '/dramas/new', icon: <PlusCircleOutlined />, label: '新建剧集' },
  ];

  const handleLogout = () => {
    localStorage.removeItem('admin_token');
    message.success('已退出');
    navigate('/login');
  };

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider collapsible collapsed={collapsed} onCollapse={setCollapsed}>
        <div style={{
          height: 48, margin: 16, display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: '#ff4d4f', fontWeight: 'bold', fontSize: collapsed ? 14 : 18,
        }}>
          {collapsed ? 'CMS' : 'AI短剧 CMS'}
        </div>
        <Menu
          theme="dark"
          mode="inline"
          selectedKeys={[location.pathname]}
          items={menuItems}
          onClick={({ key }) => navigate(key)}
        />
      </Sider>
      <Layout>
        <Header style={{
          background: '#141414', padding: '0 24px',
          display: 'flex', alignItems: 'center', justifyContent: 'flex-end',
        }}>
          <Button type="text" icon={<LoginOutlined />} onClick={handleLogout}
            style={{ color: '#999' }}>
            退出
          </Button>
        </Header>
        <Content style={{ margin: 24 }}>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/dramas" element={<DramaList />} />
            <Route path="/dramas/new" element={<DramaForm />} />
            <Route path="/login" element={<Login />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </Content>
      </Layout>
    </Layout>
  );
}

export default function App() {
  return (
    <ConfigProvider theme={{
      algorithm: theme.darkAlgorithm,
      token: { colorPrimary: '#ff4d4f' },
    }}>
      <BrowserRouter>
        <AppLayout />
      </BrowserRouter>
    </ConfigProvider>
  );
}

import { createBrowserRouter, Navigate, type RouteObject } from 'react-router';
import { NoticeListPage } from '../features/notices/pages/NoticeListPage';
import { NotFoundPage } from './NotFoundPage';
import { routes } from './routes';

export const appRoutes: RouteObject[] = [
  { path: routes.home, element: <Navigate to={routes.notices} replace /> },
  { path: routes.notices, element: <NoticeListPage /> },
  { path: routes.notFound, element: <NotFoundPage /> },
];

export const router = createBrowserRouter(appRoutes);

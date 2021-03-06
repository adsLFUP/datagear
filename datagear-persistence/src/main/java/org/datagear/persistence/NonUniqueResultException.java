/*
 * Copyright 2018 datagear.tech. All Rights Reserved.
 */

package org.datagear.persistence;

/**
 * 非唯一结果异常。
 * 
 * @author datagear@163.com
 *
 */
public class NonUniqueResultException extends PersistenceException
{
	private static final long serialVersionUID = 1L;

	public NonUniqueResultException()
	{
		super();
	}

	public NonUniqueResultException(String message)
	{
		super(message);
	}

	public NonUniqueResultException(Throwable cause)
	{
		super(cause);
	}

	public NonUniqueResultException(String message, Throwable cause)
	{
		super(message, cause);
	}
}
